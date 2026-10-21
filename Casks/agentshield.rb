cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2489"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2489/agentshield_0.2.2489_darwin_amd64.tar.gz"
      sha256 "284e76f0d4ccf29cadf3a335fb6283425a09a0fa75f7ceda15a6756444141ed2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2489/agentshield_0.2.2489_darwin_arm64.tar.gz"
      sha256 "c739cfee949da5369fa5a9889c672b607924350751ec03c7d8e70f1885f170f2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2489/agentshield_0.2.2489_linux_amd64.tar.gz"
      sha256 "c33655884cfbe9a101fec6b41a862a54d6368b0e945f44dbafb55168a4e33707"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2489/agentshield_0.2.2489_linux_arm64.tar.gz"
      sha256 "c310bb79d97c76cfaf0cb4905e3e3e7b960d8b59fb01dfd9df1c2f8c8427663f"
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
