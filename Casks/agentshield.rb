cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1016"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1016/agentshield_0.2.1016_darwin_amd64.tar.gz"
      sha256 "9a0e7213ecf56fec206eafff1df14eef42d378da60917d394d35784e1cbae473"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1016/agentshield_0.2.1016_darwin_arm64.tar.gz"
      sha256 "8c331ee4a7a870c37a1597e08e3dd20b6a39fc5cb72128ad26a3530c77ca8302"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1016/agentshield_0.2.1016_linux_amd64.tar.gz"
      sha256 "f3d8bbdc153611bbb32abb065a94ef7d594de494b71d106e19c84a55bb04dca4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1016/agentshield_0.2.1016_linux_arm64.tar.gz"
      sha256 "04d8e29a6a341f84d0be0a963f89a2dcbdc6705d2642936cce451392207fa4a1"
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
