cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.41"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.41/agentshield_0.2.41_darwin_amd64.tar.gz"
      sha256 "bb0073a66e29f529c5ab5d9ccbbb5c173ed368d1e7de842e981644487c2b62dd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.41/agentshield_0.2.41_darwin_arm64.tar.gz"
      sha256 "4c38ef4991e591f917c4ab111793693d5db1bcc77911d9f41130f6b2fda9581f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.41/agentshield_0.2.41_linux_amd64.tar.gz"
      sha256 "5098406a835747eee19d171f771ba2f288410e61b9d2989d75e56f9da41636fb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.41/agentshield_0.2.41_linux_arm64.tar.gz"
      sha256 "842abf7d31ede2eecab41b4532716bc82324fd8ff16b033e99f42eec1aeec707"
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
