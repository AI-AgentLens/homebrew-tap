cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.62"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.62/agentshield_0.2.62_darwin_amd64.tar.gz"
      sha256 "e7dc197a5bac925f777deb25816f97e898f4420fdf25b7308091f367dcde74fb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.62/agentshield_0.2.62_darwin_arm64.tar.gz"
      sha256 "fe503ba384b722c1538c09074d06fc481f6ba1b76e9f50e99209a878ff17e69c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.62/agentshield_0.2.62_linux_amd64.tar.gz"
      sha256 "aaced99148b3e1f04d5a956e3545f557896b5f4e2af286d49ae58bfe4a29958a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.62/agentshield_0.2.62_linux_arm64.tar.gz"
      sha256 "8f4365603c74810fb329caac5c5c7cc19b97171fa37ad7370d2ea96f1f9fc7f0"
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
