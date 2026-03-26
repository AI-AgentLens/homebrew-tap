cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.32"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.32/agentshield_0.2.32_darwin_amd64.tar.gz"
      sha256 "82c42daa968466022c98fc61e6a3f10f2d2463a2ff02f2c4189870f013b44ed8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.32/agentshield_0.2.32_darwin_arm64.tar.gz"
      sha256 "70cc1e89f1a0915f27b5f3b4902ab4d5c0bff950087d5a96e42bde9c908fab7a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.32/agentshield_0.2.32_linux_amd64.tar.gz"
      sha256 "03a80f3e1f6ec021e602d0ff4a23ff6a5d7dc12b9d51af75f700c811491d666f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.32/agentshield_0.2.32_linux_arm64.tar.gz"
      sha256 "bbe0b215519257ca6b015fce4dc86a79b240bcb394ed76596b73471bf52ad1cd"
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
