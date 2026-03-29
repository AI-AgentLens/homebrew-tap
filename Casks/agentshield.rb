cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.213"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.213/agentshield_0.2.213_darwin_amd64.tar.gz"
      sha256 "bed53e25236b71308455f9c1853445172aa1fa907caa514906a196efc4aede77"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.213/agentshield_0.2.213_darwin_arm64.tar.gz"
      sha256 "c07403933b1fe51a37511393fbf9f2bb925e18b9fd9dbc4ebeb3ad3d1bd3aa53"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.213/agentshield_0.2.213_linux_amd64.tar.gz"
      sha256 "61fdd06961b53e22520fe203b84b927f8764835a665a54978777f65024fa1099"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.213/agentshield_0.2.213_linux_arm64.tar.gz"
      sha256 "8d59f4a044af5654c370a7f80ac44434f6b328d71856d62f12203be7c50f8cff"
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
