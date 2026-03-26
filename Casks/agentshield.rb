cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.66"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.66/agentshield_0.2.66_darwin_amd64.tar.gz"
      sha256 "5c6cacfced52f2b2b610b1b5348922b2297a40e8316e6fd3ff166e092fcbe4fc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.66/agentshield_0.2.66_darwin_arm64.tar.gz"
      sha256 "605f4d3daed5a6231542bb9e5cfa3b8443a1b92c342821502f352c6859bbeec9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.66/agentshield_0.2.66_linux_amd64.tar.gz"
      sha256 "0f51b07d7cc7b658ee372f5215636a2ac97505896ad12e356fec25281c2610cf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.66/agentshield_0.2.66_linux_arm64.tar.gz"
      sha256 "926fbeab3ad19acdcf21024aa69f3e17c6e5171747204fc852f02601f2d2af7e"
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
