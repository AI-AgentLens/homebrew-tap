cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.628"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.628/agentshield_0.2.628_darwin_amd64.tar.gz"
      sha256 "0082ae18b1046a20ce7cf38798dd5c2966477eaa259434c264ef4782cc8dd8b7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.628/agentshield_0.2.628_darwin_arm64.tar.gz"
      sha256 "cb7fa32b566e4a9c001e737c160075434781b05cacb10af2fd1a9fdb7a3495cf"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.628/agentshield_0.2.628_linux_amd64.tar.gz"
      sha256 "370efc2c14a4b83e78afe10f1cf4d3dea8fd55795dd9a1bd12d9d6b979ee2af3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.628/agentshield_0.2.628_linux_arm64.tar.gz"
      sha256 "045bc4ad60d4a0d98fecfa56f7ecb8cd0552355614995b80ce0beb83dbeeb2ed"
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
