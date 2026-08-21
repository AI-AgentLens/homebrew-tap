cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1919"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1919/agentshield_0.2.1919_darwin_amd64.tar.gz"
      sha256 "900881dfda50aefd13ca24352b9cbc130bf242c3bfaa8d329686efbcf0d5ed8d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1919/agentshield_0.2.1919_darwin_arm64.tar.gz"
      sha256 "21475c2cf658c50515cbb70b5bb9f4e5293ca4c5f6190c18cd9786eb27dcdfdb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1919/agentshield_0.2.1919_linux_amd64.tar.gz"
      sha256 "602a8bdd6fadb498b6f4342295ec82a02271079406d062e8928bec299ccc628c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1919/agentshield_0.2.1919_linux_arm64.tar.gz"
      sha256 "3fd6b52257273ce067657f360d10fa68ffaea6f96ab92087a222f6fe6f3a6cd2"
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
