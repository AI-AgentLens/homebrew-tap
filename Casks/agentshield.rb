cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2046"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2046/agentshield_0.2.2046_darwin_amd64.tar.gz"
      sha256 "f49438f6e89acb2e73e3d69cd646a6b8e47a15426a12d2d841ffaf4231b0a0a7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2046/agentshield_0.2.2046_darwin_arm64.tar.gz"
      sha256 "73fd6a9141025002abad7b33c980857cdf811becff7ff76dd50b1b03197cb29e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2046/agentshield_0.2.2046_linux_amd64.tar.gz"
      sha256 "4ff34fa7ead5515635537668f653b5a588374be60096caf73080900448d6efdb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2046/agentshield_0.2.2046_linux_arm64.tar.gz"
      sha256 "6f4e7009ce982445b9eacbac1377fabd624e3839c69a72f7a6e404248fb0db9f"
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
