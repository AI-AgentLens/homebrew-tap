cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2383"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2383/agentshield_0.2.2383_darwin_amd64.tar.gz"
      sha256 "e2a6a15c37d8311d8f742c439b3cad9589786c7f47c632309d28f22668c6055b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2383/agentshield_0.2.2383_darwin_arm64.tar.gz"
      sha256 "f2e3e2a4859d3d70322c0b0f664c5dbace2fcb3e016e2a0558bad6f310191231"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2383/agentshield_0.2.2383_linux_amd64.tar.gz"
      sha256 "ec07d2a1525c5998fb7155fdd21c24f04ab00344f8f5f45f9ff650a0e86cfaee"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2383/agentshield_0.2.2383_linux_arm64.tar.gz"
      sha256 "94cd8309e3e2614e1eaf98f33d73c0fbc87f93262d1feaea25509132573cced7"
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
