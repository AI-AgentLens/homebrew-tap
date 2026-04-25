cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.732"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.732/agentshield_0.2.732_darwin_amd64.tar.gz"
      sha256 "307c68a756a462dff689252c6e25725b68a2baf197e1cc981c2d8d85cba01fef"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.732/agentshield_0.2.732_darwin_arm64.tar.gz"
      sha256 "8f8bda5f0a9b017ee58c46529ba96da481a7cc354f3c9a928b623eefe3f51514"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.732/agentshield_0.2.732_linux_amd64.tar.gz"
      sha256 "e8ebab4ea4b518da6eddef75c6488bef585d3cf5679411408ad457f517ee9f38"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.732/agentshield_0.2.732_linux_arm64.tar.gz"
      sha256 "e5040b31bb72350ac67eb72d16f85b4ea45a506fff9edcadc5b5e5dd4699511b"
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
