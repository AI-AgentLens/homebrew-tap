cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.25"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.25/agentshield_0.2.25_darwin_amd64.tar.gz"
      sha256 "d9332f7d4abebcdee980feada31bcf1d752e564deae30835fb81fc8846562bbf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.25/agentshield_0.2.25_darwin_arm64.tar.gz"
      sha256 "6e0979e313e78162e252f788c3a52201151721254d6b1ae3c8cabf44c3a3079a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.25/agentshield_0.2.25_linux_amd64.tar.gz"
      sha256 "b7c2a272397d3e10e3c31dc5038e83a7d52e08bff56b86dda1a804ea2379f3a6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.25/agentshield_0.2.25_linux_arm64.tar.gz"
      sha256 "d8f1a8ecfea53bf521fe07307247f30719c414cc491832108ffaeeaf1917eb1f"
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
