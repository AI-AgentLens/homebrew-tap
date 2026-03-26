cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.37"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.37/agentshield_0.2.37_darwin_amd64.tar.gz"
      sha256 "56204e5cfb11d246679cefdabeffcefb982a64019ec1d9689440a0862d137747"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.37/agentshield_0.2.37_darwin_arm64.tar.gz"
      sha256 "d06f993580c94ff22a2dc9aa64877cb8addb493b46181dc8d25b94b6da32deb8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.37/agentshield_0.2.37_linux_amd64.tar.gz"
      sha256 "0eab860f6dff649f9bf16ed40a751f8b4f889028972f5ebf1761e26a18397fc8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.37/agentshield_0.2.37_linux_arm64.tar.gz"
      sha256 "97afef2ca97dbde61959a939de25d047fd11bf8f8c98307e7b052c5b0ec4ff0c"
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
