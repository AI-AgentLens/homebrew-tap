cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.762"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.762/agentshield_0.2.762_darwin_amd64.tar.gz"
      sha256 "8c49e80001e4ca52cc4c6eac8a79c6d8c21a2b3ec7ee34a0279051b4bc7159f9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.762/agentshield_0.2.762_darwin_arm64.tar.gz"
      sha256 "5acde40c42e71d9135461bc904711e2e6e3d35b3d030f2427ec2a67b1145601a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.762/agentshield_0.2.762_linux_amd64.tar.gz"
      sha256 "23524a71da914e2bbdb493d266841cfa2cacd9aec76ae85d28666d4fa1f9b81e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.762/agentshield_0.2.762_linux_arm64.tar.gz"
      sha256 "01d529313722f3c0754774045006ab0deb96dd7e429a79ac6f560fc8c0690189"
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
