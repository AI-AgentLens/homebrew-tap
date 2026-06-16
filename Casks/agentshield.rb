cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1333"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1333/agentshield_0.2.1333_darwin_amd64.tar.gz"
      sha256 "3aa951951e3f029641499937288039b86cfea3fa4b5660279f516c810595c702"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1333/agentshield_0.2.1333_darwin_arm64.tar.gz"
      sha256 "80797ed79b34eee3433706c2763c8da04a980e9259111486581678480b5682d3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1333/agentshield_0.2.1333_linux_amd64.tar.gz"
      sha256 "3894ddfa172644dfb73a3513ff5c04395da7967063b8834ee9b9e096b9c1432e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1333/agentshield_0.2.1333_linux_arm64.tar.gz"
      sha256 "7338e661c839204858f7a197c0448bb2d0b0ab2093451b77b6fbcbbf2210dfea"
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
