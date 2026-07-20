cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1688"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1688/agentshield_0.2.1688_darwin_amd64.tar.gz"
      sha256 "9fc299136d10ac1ac3c8f99c2f886ebc0c010e0e9d1fffeacaa630e85447aa5d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1688/agentshield_0.2.1688_darwin_arm64.tar.gz"
      sha256 "ae864110b965fcf4ffd63b502651fbc2282e84a9ee799609a937751a49a405a7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1688/agentshield_0.2.1688_linux_amd64.tar.gz"
      sha256 "6192dfddac9f4837479039cf462b13e0a964e6411bdfbdb2e61c3525a57cbd1d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1688/agentshield_0.2.1688_linux_arm64.tar.gz"
      sha256 "adff71d09adf9177bbc64cf24687cec1f9105ecefa01dd0061ba27a978cce736"
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
