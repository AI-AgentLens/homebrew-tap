cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.152"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.152/agentshield_0.2.152_darwin_amd64.tar.gz"
      sha256 "efcb9327e733f6fe454310fcb2f1ac8be41bdfcc1478d865dd04209d945271bb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.152/agentshield_0.2.152_darwin_arm64.tar.gz"
      sha256 "0dd371b7094daa9a9e628de3b3b78b8f3bb97072ab8d8d1dc041cee3ca71d7c1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.152/agentshield_0.2.152_linux_amd64.tar.gz"
      sha256 "4ad90344b18e7f4a9db067872352dfbc7e8829acbb75da5d7be1cefd51f9b95a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.152/agentshield_0.2.152_linux_arm64.tar.gz"
      sha256 "39d5c9d45e76aab5a43d8097fd7d2e27d3a290ee647e4da7ca810ea59c147cc9"
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
