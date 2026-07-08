cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1583"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1583/agentshield_0.2.1583_darwin_amd64.tar.gz"
      sha256 "3edcd590e1327b4be83356520547a781bf93018717e12938b5f195e31fcfa4af"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1583/agentshield_0.2.1583_darwin_arm64.tar.gz"
      sha256 "c38cab238977c98c296ac9e88b62e3272b727cbdc31b004e4f92c40f4da3dd12"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1583/agentshield_0.2.1583_linux_amd64.tar.gz"
      sha256 "1f708e002de92b2466a805b261b328940d5ccffe2479313b7211a39042f17989"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1583/agentshield_0.2.1583_linux_arm64.tar.gz"
      sha256 "567aac4a3951ce1c11a5226bd8d5cfbef5c203a91b3da0cd01ae7bbd2f67f531"
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
