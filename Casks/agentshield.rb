cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.79"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.79/agentshield_0.2.79_darwin_amd64.tar.gz"
      sha256 "385c1a32fb64d092f57dc0962115d085d0b62285df986f0c5edffc58e7aa8e83"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.79/agentshield_0.2.79_darwin_arm64.tar.gz"
      sha256 "3df49897783ea8b64971f471140f3ed3025fa40b6b0fb63c09a24cf70844bd0e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.79/agentshield_0.2.79_linux_amd64.tar.gz"
      sha256 "bd79570cbcdee79a697461a7a9c883c38e8e9c80934420198dcb448341444cb7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.79/agentshield_0.2.79_linux_arm64.tar.gz"
      sha256 "39c0c4624a6a431493d7931dfaaae7cc1a26528bde1e676f7dc8d456c8cf9a3e"
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
