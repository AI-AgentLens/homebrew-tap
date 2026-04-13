cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.578"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.578/agentshield_0.2.578_darwin_amd64.tar.gz"
      sha256 "062018a6b61ba3412d5f4c0287391b5108e84e9f0dec460eac152fd44cec309d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.578/agentshield_0.2.578_darwin_arm64.tar.gz"
      sha256 "00413abed498886263bfeaa9ae496af7f225ccfcc0f9fe2cd57fac1615a60b4c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.578/agentshield_0.2.578_linux_amd64.tar.gz"
      sha256 "9b55687ca5e272aef5f4f1c08459b6f235fdd91ef098fc45d0207cc9c66f3740"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.578/agentshield_0.2.578_linux_arm64.tar.gz"
      sha256 "c8459a4e47460df2af249527ceaa6415e7843dcb675468d728d4bb786d8ce0c4"
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
