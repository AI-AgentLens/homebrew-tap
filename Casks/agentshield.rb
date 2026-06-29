cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1489"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1489/agentshield_0.2.1489_darwin_amd64.tar.gz"
      sha256 "932fab695fa844af8c895bc353299a041f1956b70e61b9c22ad84c2db7cc46fc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1489/agentshield_0.2.1489_darwin_arm64.tar.gz"
      sha256 "a4af7be80726d9b98816406989b423a4ead85ca37fff7d358116337b0406e702"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1489/agentshield_0.2.1489_linux_amd64.tar.gz"
      sha256 "c3ae487ce43ebc19c55974712ebcd6f2ce09c5b155257c725fab946d840b2d62"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1489/agentshield_0.2.1489_linux_arm64.tar.gz"
      sha256 "097b0ddbc6ce376b25110f376645ef9ffc03217841381461854cf1cfa6067fba"
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
