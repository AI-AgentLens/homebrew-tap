cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.593"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.593/agentshield_0.2.593_darwin_amd64.tar.gz"
      sha256 "ddf23bc34f8dbbb7612b7c3f0715f9870772ca2e9b167e0fc27cc62e8206d472"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.593/agentshield_0.2.593_darwin_arm64.tar.gz"
      sha256 "86aa47813d3d4ecd1695436bc7706ca3a9f9f5e79abc23efa2b160e47b316a03"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.593/agentshield_0.2.593_linux_amd64.tar.gz"
      sha256 "048e395b58fd84bf127a66e87246e632ea64c1eb1853e5e92a84b91d68455d59"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.593/agentshield_0.2.593_linux_arm64.tar.gz"
      sha256 "de3db662b5ad77d22519cc2ed4e6fd7964e9e6f91da515b4f135cf591492b194"
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
