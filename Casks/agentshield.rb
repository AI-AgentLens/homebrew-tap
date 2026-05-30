cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1158"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1158/agentshield_0.2.1158_darwin_amd64.tar.gz"
      sha256 "384d9e7380dc5b054c7a32bc5f6db3a9be6e3061023038b8083a1e737e97457b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1158/agentshield_0.2.1158_darwin_arm64.tar.gz"
      sha256 "18ea3735cb6e1e2822bb222c47feb9049989ec3648f16a97ac3c4a0cf7bd4975"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1158/agentshield_0.2.1158_linux_amd64.tar.gz"
      sha256 "3dc40da6d1b2dbd1d8019a524bfc8c310533be3831ac55f9e7614207e2a128de"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1158/agentshield_0.2.1158_linux_arm64.tar.gz"
      sha256 "ea8d0f40d320021a9bdd233d16883e49910ab6e5547cebfdb36f0de366fb7f0a"
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
