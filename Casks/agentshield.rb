cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.12"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.12/agentshield_0.2.12_darwin_amd64.tar.gz"
      sha256 "5e48ba53091054c00fdad245218247067da41bc65a1c071ca4e931a42e1b049e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.12/agentshield_0.2.12_darwin_arm64.tar.gz"
      sha256 "7ab80aacb6e81634bbf04a09cbe06ce655134c0a47244fecc5f3fe77c58a22bd"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.12/agentshield_0.2.12_linux_amd64.tar.gz"
      sha256 "82895a84995ebcac1a852421f7c35ff4d17788a7c3b3622c2af34fe365335ce0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.12/agentshield_0.2.12_linux_arm64.tar.gz"
      sha256 "b4bf998bb9477d01020ea7918b8275a578c4cbff99ed3ec384a8aeabb197c275"
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
