cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.611"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.611/agentshield_0.2.611_darwin_amd64.tar.gz"
      sha256 "ef2b02bbd7e6558bb94404fd06fe80ff7382fdb9be9af67c8d70486c18bdf600"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.611/agentshield_0.2.611_darwin_arm64.tar.gz"
      sha256 "23b591a7d2bd289bd8ee4fde7fdf411dafb922e33ed74988c074b72c7c57187d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.611/agentshield_0.2.611_linux_amd64.tar.gz"
      sha256 "2788fa885ed2499ef5d96f2fb0499c48317ee16173dd9bab6d6ea01fafb7f713"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.611/agentshield_0.2.611_linux_arm64.tar.gz"
      sha256 "fb76c27a403a03ce6131d67778c43a34a032cb17c278292a367cb601f5c3ef4d"
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
