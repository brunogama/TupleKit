#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

fail() {
    printf '%s\n' "$*" >&2
    exit 1
}

[[ $# == 3 ]] || fail "Usage: $0 vMAJOR.MINOR.PATCH OWNER/REPO OUTPUT_DIR"
tag=$1
repository=$2
output=$3
stable_tag='^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$'
repository_name='^[a-zA-Z0-9]+(-[a-zA-Z0-9]+)*/[a-zA-Z0-9_.-]{1,100}$'
owner=${repository%%/*}
repo=${repository#*/}
[[ $tag =~ $stable_tag ]] || fail "Expected a stable tag: vMAJOR.MINOR.PATCH"
[[ $repository =~ $repository_name && ${#owner} -le 39 && $repo != . && $repo != .. ]] \
    || fail "Expected a GitHub repository: OWNER/REPO"
[[ -n $output ]] || fail "Expected a nonempty output directory path"
[[ $output == /* ]] || output="$PWD/$output"
[[ -d $output || ( ! -e $output && ! -L $output ) ]] || fail "Not a directory: $output"

products=(TupleKit TupleKitComposition)
for asset in Package.binary.swift "${products[@]/%/.xcframework.zip}"; do
    [[ ! -e $output/$asset && ! -L $output/$asset ]] || fail "Output already exists: $output/$asset"
done

root=$(cd "$(dirname "$0")/.." && pwd)
scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT
source_dir="$scratch/source"
artifacts="$scratch/artifacts"
mkdir "$source_dir" "$artifacts"
git -C "$root" archive HEAD | tar -x -C "$source_dir"

awk -v products="${products[*]}" '
    BEGIN { count = split(products, names, " ") }
    {
        for (i = 1; i <= count; i++) {
            name = names[i]
            if (earlier == "    .library(" && previous == "      name: \"" name "\"," &&
                $0 == "      targets: [\"" name "\"]") {
                print "      type: .dynamic,"
                rewrites[name]++
            }
        }
        print
        earlier = previous
        previous = $0
    }
    END {
        for (i = 1; i <= count; i++) {
            if (rewrites[names[i]] != 1) exit 1
        }
    }
' "$source_dir/Package.swift" > "$scratch/Package.swift" \
    || fail "Expected one implicit library declaration per product in archived Package.swift"
mv "$scratch/Package.swift" "$source_dir/Package.swift"

embed_swift_modules() {
    local product=$1 build_products=$2 framework=$3
    local swiftmodule="$build_products/$product.swiftmodule" modules="$framework/Modules" interface
    [[ -d $framework && -d $swiftmodule ]] || fail "Missing $product framework or Swift module in $build_products"
    if [[ -d $framework/Versions/A ]]; then
        modules="$framework/Versions/A/Modules"
        if [[ ! -e $framework/Modules && ! -L $framework/Modules ]]; then
            ln -s Versions/Current/Modules "$framework/Modules"
        fi
    fi
    mkdir -p "$modules"
    ditto "$swiftmodule" "$modules/$product.swiftmodule"
    interface=$(find "$framework/Modules/$product.swiftmodule" -type f -name '*.swiftinterface' \
        ! -name '*.private.swiftinterface' ! -name '*.package.swiftinterface' -print -quit)
    [[ -n $interface ]] || fail "Missing public Swift interface in $framework"
}

build_product() {
    local product=$1 platform suffix architectures derived build_products framework
    local -a frameworks=()
    while IFS='|' read -r platform suffix architectures; do
        derived="$scratch/$product$suffix"
        build_products="$derived/Build/Products/Release$suffix"
        framework="$build_products/PackageFrameworks/$product.framework"
        (
            cd "$source_dir"
            # Use a framework bundle for Swift modules, but link its code statically.
            xcodebuild -scheme "$product" -destination "generic/platform=$platform" \
                -configuration Release -derivedDataPath "$derived" BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
                MACH_O_TYPE=staticlib CODE_SIGNING_ALLOWED=NO ONLY_ACTIVE_ARCH=NO "ARCHS=$architectures" build
        ) </dev/null
        embed_swift_modules "$product" "$build_products" "$framework"
        frameworks+=(-framework "$framework")
    done <<'SLICES'
macOS||arm64 x86_64
iOS|-iphoneos|arm64
iOS Simulator|-iphonesimulator|arm64 x86_64
SLICES
    xcodebuild -create-xcframework "${frameworks[@]}" -output "$scratch/$product.xcframework"
    ditto -c -k --keepParent "$scratch/$product.xcframework" "$artifacts/$product.xcframework.zip"
}

write_manifest() {
    local product zip checksum base_url="https://github.com/$repository/releases/download/$tag"
    cat <<'SWIFT'
// swift-tools-version: 6.4.2

import PackageDescription

let package = Package(
  name: "TupleKit",
  platforms: [.macOS(.v14), .iOS(.v17)],
  products: [
SWIFT
    for product in "${products[@]}"; do
        printf '    .library(name: "%s", targets: ["%s"]),\n' "$product" "$product"
    done
    printf '  ],\n  targets: [\n'
    for product in "${products[@]}"; do
        zip="$product.xcframework.zip"
        checksum=$(swift package compute-checksum "$artifacts/$zip")
        [[ $checksum =~ ^[0-9a-f]{64}$ ]] || fail "Expected a SHA-256 checksum for $zip"
        printf '    .binaryTarget(\n      name: "%s",\n      url: "%s/%s",\n      checksum: "%s"\n    ),\n' \
            "$product" "$base_url" "$zip" "$checksum"
    done
    printf '  ],\n  swiftLanguageModes: [.v6]\n)\n'
}

for product in "${products[@]}"; do
    build_product "$product"
done
write_manifest > "$artifacts/Package.binary.swift"
mkdir -p "$output"
mv "$artifacts"/* "$output/"
