cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.491"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.491/agentshield_0.2.491_darwin_amd64.tar.gz"
      sha256 "b0b4646272920c2f96c74fd836bec93123f26e52f4acc5af4441f4c0f2331cf1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.491/agentshield_0.2.491_darwin_arm64.tar.gz"
      sha256 "e42863c6beffb39011c1ba8cd885869edc96ae11ef498ba3fd44c44847b6d92d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.491/agentshield_0.2.491_linux_amd64.tar.gz"
      sha256 "75037c8612fc0af7bcd861f1d505d2c9abcbbe14596f9ac641b1c0e152bb042b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.491/agentshield_0.2.491_linux_arm64.tar.gz"
      sha256 "6aa80244ad167571973599c07be3c379c3a4f8e307347a87f7499436107822c4"
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
