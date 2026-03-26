cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.74"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.74/agentshield_0.2.74_darwin_amd64.tar.gz"
      sha256 "aea629d2a9e4d53c2f03a6db2cece117aa7adecf69167fca9f5e5067eddf9afd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.74/agentshield_0.2.74_darwin_arm64.tar.gz"
      sha256 "acf9795d8046a8a5e77aad7bf26d356a64447757f58c8742cae8c3ca7f96de9d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.74/agentshield_0.2.74_linux_amd64.tar.gz"
      sha256 "585b0d3c3e1bf3245e48755382500382248663e94715e207194a71a70bd45020"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.74/agentshield_0.2.74_linux_arm64.tar.gz"
      sha256 "e87515d38431d2946cb52afc60ef7e0b10901c205c2b30030a354a81614fe416"
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
