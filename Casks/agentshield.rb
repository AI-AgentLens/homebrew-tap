cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1659"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1659/agentshield_0.2.1659_darwin_amd64.tar.gz"
      sha256 "b9ae1b710800d9229526c16ad7607fdf3d67e514d83f967bac0fb2ddbd966780"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1659/agentshield_0.2.1659_darwin_arm64.tar.gz"
      sha256 "ac79cb3edaa983c1fda9be96f3dc17e99fbf7c203c4faa7a4b46489659325492"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1659/agentshield_0.2.1659_linux_amd64.tar.gz"
      sha256 "ca505f31dbefd8ea559fa2f63f4cc0bba6662fd95a509e04984b68f5739775bb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1659/agentshield_0.2.1659_linux_arm64.tar.gz"
      sha256 "f23aa04be416e682b61c5a310f6227feac3d535acd02ccf2ca8fdf7e0dd8dfdd"
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
