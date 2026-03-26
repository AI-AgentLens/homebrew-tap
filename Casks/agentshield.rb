cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.17"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.17/agentshield_0.2.17_darwin_amd64.tar.gz"
      sha256 "d0eff021bb3c4fd6e27f5a11a99e8d20f2f940344c55050bc48ba3b29207e3c6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.17/agentshield_0.2.17_darwin_arm64.tar.gz"
      sha256 "634d8323d54c62e373e91fa485819f988e3988973bffbfd25f3181d13fbef646"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.17/agentshield_0.2.17_linux_amd64.tar.gz"
      sha256 "aeab42839e797b64b3cba30014af2b57dc62cf87db75d81edf9d60fb0d27b950"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.17/agentshield_0.2.17_linux_arm64.tar.gz"
      sha256 "f999e54e531394075400240afb54d2f5f103474ab7c9cb93065915b843bf4424"
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
