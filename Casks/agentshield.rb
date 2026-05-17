cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1007"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1007/agentshield_0.2.1007_darwin_amd64.tar.gz"
      sha256 "1f4f1995a751167b011f6ecbbcf5eea8521d9fe3c658806a14b9b92d9078a4ab"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1007/agentshield_0.2.1007_darwin_arm64.tar.gz"
      sha256 "a4962bc612c25350e4e6717c040d671bdbf4f7dd09f843f30ec92e4c5851157b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1007/agentshield_0.2.1007_linux_amd64.tar.gz"
      sha256 "54d58880248e9946af52d7e828e145abfee5d2f6090aeae07199b9fee8bfe3c6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1007/agentshield_0.2.1007_linux_arm64.tar.gz"
      sha256 "5b9c31a8664a4d2f559a70d57dd6b4caf47f7ab688a2d42dfe4be3df9bdb6743"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
