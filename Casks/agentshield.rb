cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2457"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2457/agentshield_0.2.2457_darwin_amd64.tar.gz"
      sha256 "fb6987eebf7209d42ec8058c6161c06381998ff64e0fc31237aad7276d209fff"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2457/agentshield_0.2.2457_darwin_arm64.tar.gz"
      sha256 "9aec2a9d562dfc06784a0a8afb6d37070b5e10423237f917c9701a83d6aac5a5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2457/agentshield_0.2.2457_linux_amd64.tar.gz"
      sha256 "e110b3b2af96617628e37386a30aa4c3ae3437a2604ce72adf4c5aa94e7b1023"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2457/agentshield_0.2.2457_linux_arm64.tar.gz"
      sha256 "7f6d283288af6bede3778c9000a53b7520c417655db52cb8493a94d5cb10f991"
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
