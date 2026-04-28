cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.785"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.785/agentshield_0.2.785_darwin_amd64.tar.gz"
      sha256 "58e59ebb53d18dd68ff37de2f79aed4d53572e96c6b297f305abe87670094dfa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.785/agentshield_0.2.785_darwin_arm64.tar.gz"
      sha256 "2cde1f7b1defac4fde0bc51de89bb2b862da23484f2f5913f24d41199bf6f6e1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.785/agentshield_0.2.785_linux_amd64.tar.gz"
      sha256 "0c45abaac33e454a9cfd85e877e9d1260e3febe38c66d2ba27bab1d7e6dc3203"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.785/agentshield_0.2.785_linux_arm64.tar.gz"
      sha256 "6141cf432175244b7558d43f92db4e315a724335af841b838567f80251f2ca74"
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
