cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.46"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.46/agentshield_0.2.46_darwin_amd64.tar.gz"
      sha256 "ddb2c0d4cc5123e937d4f8e948bcb1f1330fea98587dc6c93b4447f486b74b66"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.46/agentshield_0.2.46_darwin_arm64.tar.gz"
      sha256 "d5332549d37c49d68eba7d82f7ce9cb0b8c608ca19e3db17b30a0e2bbe588049"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.46/agentshield_0.2.46_linux_amd64.tar.gz"
      sha256 "40416f4be10db82900363a71c5f6a1cc6d1b190928fc4bd2ecaee9d56ac4f8a4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.46/agentshield_0.2.46_linux_arm64.tar.gz"
      sha256 "548f45b946c3eb94927e3f7577ec4f54afc647da373f72a0078aadd5214d0c0e"
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
