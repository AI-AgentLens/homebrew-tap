cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1978"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1978/agentshield_0.2.1978_darwin_amd64.tar.gz"
      sha256 "db75b374c91670800a726eb4be1d7f28a6ff12272741795d3d99b61dcf3002b6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1978/agentshield_0.2.1978_darwin_arm64.tar.gz"
      sha256 "2020c95a209daba40e76212934a16cd8c5bced0d832814a5108106c71d01b366"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1978/agentshield_0.2.1978_linux_amd64.tar.gz"
      sha256 "7cd312b6998385d3ce5bd791d620aa3bf99cb54e90899109b30ac800767f97b3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1978/agentshield_0.2.1978_linux_arm64.tar.gz"
      sha256 "a6128a1658d342f429a8092f33a3f785bf9ca44733ac24941be2b785096c9b69"
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
