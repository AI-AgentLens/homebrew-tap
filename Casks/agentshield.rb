cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1082"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1082/agentshield_0.2.1082_darwin_amd64.tar.gz"
      sha256 "5fad8adf9d86f9929e82075f3ae84a5d87cc192897bf07b00561217dc11126aa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1082/agentshield_0.2.1082_darwin_arm64.tar.gz"
      sha256 "c01c554b6691bc068417aa00e17e46b4b39b40d34044cb92d70bd0c607c60c85"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1082/agentshield_0.2.1082_linux_amd64.tar.gz"
      sha256 "632c8a5a30dbe2983e2122834739035fef39354b1834c6f6811442fe83a45426"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1082/agentshield_0.2.1082_linux_arm64.tar.gz"
      sha256 "1394702491db35f915e80fc2608f0f429135c2b338396019d009ec39bd365cc3"
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
