cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1283"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1283/agentshield_0.2.1283_darwin_amd64.tar.gz"
      sha256 "723a46ef9816e9255144ab6f4a1e0b7d29c68ad535d3ce33d8f1239a7856d921"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1283/agentshield_0.2.1283_darwin_arm64.tar.gz"
      sha256 "bf615ef460d690c049cf38afd346a81b752a357feae68c775ce2847a2c9377e0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1283/agentshield_0.2.1283_linux_amd64.tar.gz"
      sha256 "f2540597c20292796402dff895660d052aaef5f2e9c7175c64fc2b6be7f4a7a6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1283/agentshield_0.2.1283_linux_arm64.tar.gz"
      sha256 "de2ed6509a0bc682dd4c2650ad00f60677797f45d9d6cd9b9f002e536be56adb"
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
