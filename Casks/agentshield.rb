cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2281"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2281/agentshield_0.2.2281_darwin_amd64.tar.gz"
      sha256 "4d09e77f2aae2211abe770a77557a5c9ac323923efb788e91455fda5900e3122"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2281/agentshield_0.2.2281_darwin_arm64.tar.gz"
      sha256 "d34382749b0605e503726f5ea709395b596dcb60665e82c1d6ddbf93d025a145"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2281/agentshield_0.2.2281_linux_amd64.tar.gz"
      sha256 "c622003a5b84da0ec7e1aecb5b9ca68f62d7c8cda724d78af6b0e605ec80940d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2281/agentshield_0.2.2281_linux_arm64.tar.gz"
      sha256 "adb4a1dc4c5209823409df0bac7b4072dcce4b20c8ac4438d95a91f42cbe8884"
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
