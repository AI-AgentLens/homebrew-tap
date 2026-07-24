cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1719"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1719/agentshield_0.2.1719_darwin_amd64.tar.gz"
      sha256 "3996376d4d698db7ebeb061de88aa29499dc3f63b1434a1ff45387ebda15a63e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1719/agentshield_0.2.1719_darwin_arm64.tar.gz"
      sha256 "2322ed479e83c77f3094999777ef30556ef68d4e5fef3d869668edbed54b02f5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1719/agentshield_0.2.1719_linux_amd64.tar.gz"
      sha256 "302a0017742961a6f7666ce61dbf67ad4ece96bb4ffb0b0c1eda066d55396562"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1719/agentshield_0.2.1719_linux_arm64.tar.gz"
      sha256 "1cb1b427f35d53466ddaf4aff838143e3212f0618044b120fb82c4908f8263f2"
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
