cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.39"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.39/agentshield_0.2.39_darwin_amd64.tar.gz"
      sha256 "d93bbeb6ed0e465611abdf00564605713662cb91046a118f99f4f0ee64764ed8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.39/agentshield_0.2.39_darwin_arm64.tar.gz"
      sha256 "473bc7d9c5d9c7674c9b15d2bfe161ce1d1f5e2056266cef401a2e550d13c885"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.39/agentshield_0.2.39_linux_amd64.tar.gz"
      sha256 "0afe6bae28b025fb70a629dc7caa00c2446da70e5b0ed002ac5c239105ea343a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.39/agentshield_0.2.39_linux_arm64.tar.gz"
      sha256 "80eddb2ce95b57858ad7fd82b32f462c90a2bcdc3b96d5af047eb1354f1721da"
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
