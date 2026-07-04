cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1545"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1545/agentshield_0.2.1545_darwin_amd64.tar.gz"
      sha256 "4184b3e6c739efadf05966fac68ae3ebe3416c437db1f2cdb7879bf7860ca21d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1545/agentshield_0.2.1545_darwin_arm64.tar.gz"
      sha256 "df668e64e16edee31339ff76567b31d4ebd17b9df604b3b83a3aacd427987743"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1545/agentshield_0.2.1545_linux_amd64.tar.gz"
      sha256 "2462ae23ad3259c277d6e76e21f66d4f29e81bd4921ec31de5bb2050e19aa043"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1545/agentshield_0.2.1545_linux_arm64.tar.gz"
      sha256 "83480f401934e18a5788b5c45849bf3de8d7580d73d8bd45683bbf0872f4d738"
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
