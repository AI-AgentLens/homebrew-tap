cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2225"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2225/agentshield_0.2.2225_darwin_amd64.tar.gz"
      sha256 "64493bbb6532f44ea94e0df2db5630ee679dcb871e79121f4615c0f35b9fb6b6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2225/agentshield_0.2.2225_darwin_arm64.tar.gz"
      sha256 "7311f535cc3f9bc9d36a002358c1778476f298ba79ed0ca7247414aaa8f82a7f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2225/agentshield_0.2.2225_linux_amd64.tar.gz"
      sha256 "fb6475ad2146af363e1daa35e97c2199bc59d4c96b06ad7ef5609865dfb92e47"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2225/agentshield_0.2.2225_linux_arm64.tar.gz"
      sha256 "22d970f4200db1fc967b68c2e9cb7ec0989a0a48e306048a8f03728c7ccb42d3"
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
