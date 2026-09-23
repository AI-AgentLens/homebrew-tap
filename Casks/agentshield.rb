cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2238"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2238/agentshield_0.2.2238_darwin_amd64.tar.gz"
      sha256 "c42f66d207dd1823aed9a47a1364d9b7b36e5e1bb1987dc40530d39f3102a822"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2238/agentshield_0.2.2238_darwin_arm64.tar.gz"
      sha256 "f89bef389f5f6d7cf5f598ebb2dfd52a6b52bd6d696c0c34b4f1c95df5ed3783"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2238/agentshield_0.2.2238_linux_amd64.tar.gz"
      sha256 "90868b545d9403787e8ebfd100ad04cd0f123d7eff64e7198bfe210240b22aeb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2238/agentshield_0.2.2238_linux_arm64.tar.gz"
      sha256 "0e453857add59a13e38d83ac978c70a01ab68eb9664f7331f51dc01f579702f7"
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
