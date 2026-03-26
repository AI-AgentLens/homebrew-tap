cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.80"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.80/agentshield_0.2.80_darwin_amd64.tar.gz"
      sha256 "88756964357489e6df402e6c84aecda0b707c8cbf7b9783eb68ef45457b1c933"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.80/agentshield_0.2.80_darwin_arm64.tar.gz"
      sha256 "957b0afb036c755df4c14d40951bca02f5c9e8ea0e289070479570b6468086b5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.80/agentshield_0.2.80_linux_amd64.tar.gz"
      sha256 "cd5dafa1442b48cc5fd18353ec3a1a05edc4f2dfe87459a3dbd38154eee2ab5a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.80/agentshield_0.2.80_linux_arm64.tar.gz"
      sha256 "b32e29b451af61e928d9c53b5313cde4430614b986e5880977d526087cdd5f38"
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
