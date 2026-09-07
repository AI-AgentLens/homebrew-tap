cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2073"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2073/agentshield_0.2.2073_darwin_amd64.tar.gz"
      sha256 "cbc692424dc46b23b6b26cc5903359ff06a97e725b53f46138815cb44c3a5552"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2073/agentshield_0.2.2073_darwin_arm64.tar.gz"
      sha256 "e8dc9d45ab2741c2ffae41045957234479e700d9f634c52a0dce15f9aa4ecf1a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2073/agentshield_0.2.2073_linux_amd64.tar.gz"
      sha256 "17b5472203dd73fb9d8d3e7d5b401ff321ed54dd0017a8baaebc6d204562acb0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2073/agentshield_0.2.2073_linux_arm64.tar.gz"
      sha256 "f10d0d860badfd8d8d5fbe0b855869ec0ab46d19ca6f350183dbb5056445a236"
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
