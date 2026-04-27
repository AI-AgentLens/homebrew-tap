cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.771"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.771/agentshield_0.2.771_darwin_amd64.tar.gz"
      sha256 "822395974712011b36147e44a90bd4e6e236830c93ac3f84541910eb861a45b2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.771/agentshield_0.2.771_darwin_arm64.tar.gz"
      sha256 "fbd3b1a0faed0fa261eab463ee505d26e2a61ac8de176d5a3d436deb7424553b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.771/agentshield_0.2.771_linux_amd64.tar.gz"
      sha256 "26b33547b3f236486581664501a79c5582857e1df60fb68040b112dc0d42ca80"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.771/agentshield_0.2.771_linux_arm64.tar.gz"
      sha256 "e383fcf582e1fd6152a2f224489dde8b0ad4bfd965bd7d4ee6b7fe98b204d9ce"
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
