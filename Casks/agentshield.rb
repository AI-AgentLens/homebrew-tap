cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1467"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1467/agentshield_0.2.1467_darwin_amd64.tar.gz"
      sha256 "f347107eb695c0045c0a66e7002f63757259f8db9ea5aebebd0a4c7b3d283323"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1467/agentshield_0.2.1467_darwin_arm64.tar.gz"
      sha256 "324990285140c2e09d15707e743ac6edc8a9abdb5b78010c1d5f0e18057bfa63"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1467/agentshield_0.2.1467_linux_amd64.tar.gz"
      sha256 "4824ac00a949f17738d303d8a6fae0503ddd372749b1fa5215ff29da38dcd54d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1467/agentshield_0.2.1467_linux_arm64.tar.gz"
      sha256 "74824a36c2ad15616d8bffbacbcccc183ee6e9d161eacb06b0349872a52d4f36"
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
