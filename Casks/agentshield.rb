cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.147"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.147/agentshield_0.2.147_darwin_amd64.tar.gz"
      sha256 "652fe44bd891950f240b27893df2ece0917b3c5c1c81597cafdabf62d3c08dcf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.147/agentshield_0.2.147_darwin_arm64.tar.gz"
      sha256 "4968ab721e022dd26aef96cc569bcbad67f7bb5461d17729482438323a577107"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.147/agentshield_0.2.147_linux_amd64.tar.gz"
      sha256 "18e12a5df2d63d6ba6fe894054971be9dbe46319329a0e4f309bda590ff887af"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.147/agentshield_0.2.147_linux_arm64.tar.gz"
      sha256 "ec068ed11343c760551bb182b451d10a924cd74dce0a41ad50239e4e5ece3e4e"
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
