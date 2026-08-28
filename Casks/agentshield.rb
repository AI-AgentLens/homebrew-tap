cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1975"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1975/agentshield_0.2.1975_darwin_amd64.tar.gz"
      sha256 "b177ce067b3154c26798d60abb37e86d7f1a17cbf89d0858d42bc79c2eb02b4e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1975/agentshield_0.2.1975_darwin_arm64.tar.gz"
      sha256 "cc3ac49ea973f6eb9a232aba5e64df21d442f357ecd378cc63c39df49dbbba49"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1975/agentshield_0.2.1975_linux_amd64.tar.gz"
      sha256 "97e3501a98ea0c321809739820ee593aac4dabb53f295621f7ddc329db7609b0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1975/agentshield_0.2.1975_linux_arm64.tar.gz"
      sha256 "9eff757f6e250a54922005df2cfaa52f7fbe3a9e15cef28d138ec0fd3a8c029d"
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
