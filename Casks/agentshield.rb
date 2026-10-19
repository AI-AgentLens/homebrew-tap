cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2469"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2469/agentshield_0.2.2469_darwin_amd64.tar.gz"
      sha256 "39d71de529710994ec9b335515e03fe70c9241e669546822aafcf3e6a7f97adf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2469/agentshield_0.2.2469_darwin_arm64.tar.gz"
      sha256 "a4d16f14f94c3c09c9e044ad42bab6afa0d1cd60a1f6a5c5f2787d04d408625e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2469/agentshield_0.2.2469_linux_amd64.tar.gz"
      sha256 "bc0efdb0644d0e12f4c85d0d866f5ff76d46f9a0eb64569358a9c765592deae7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2469/agentshield_0.2.2469_linux_arm64.tar.gz"
      sha256 "dadbc34475f8cff30e1e75948c7e97fdfc4990c28dcb4e7bd876081f931a9f11"
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
