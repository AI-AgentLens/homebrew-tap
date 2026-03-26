cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.52"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.52/agentshield_0.2.52_darwin_amd64.tar.gz"
      sha256 "a0a71ac8876d303ca01ba18beaea8a22e8b8157acd12f5a7aabb0502cba58037"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.52/agentshield_0.2.52_darwin_arm64.tar.gz"
      sha256 "703a9446115a76fb80102e0eec0f4b8eca5e8e05d7fd48d12a5eb7fdfd899106"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.52/agentshield_0.2.52_linux_amd64.tar.gz"
      sha256 "cafffcd8c4e02110fefe864152294c28a049cd97428213231d764cfbdbf41202"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.52/agentshield_0.2.52_linux_arm64.tar.gz"
      sha256 "ab1b959e6a4eeca9d8d213de936067b1d2566ee8e10ef60fa83b08ff1203230b"
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
