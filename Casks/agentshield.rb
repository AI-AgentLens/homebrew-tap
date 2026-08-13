cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1841"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1841/agentshield_0.2.1841_darwin_amd64.tar.gz"
      sha256 "d4515d721df77b1e3c3619d30387699fb4ad47fb56fef9d85e73ba21c8fd0539"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1841/agentshield_0.2.1841_darwin_arm64.tar.gz"
      sha256 "e67ba1d121dbc1987f9356f45fe4a43170d4ecafff251792965c3e1bb7dd76e4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1841/agentshield_0.2.1841_linux_amd64.tar.gz"
      sha256 "a3b4e6660198f3cd618d3f57c1c8506ede2930c97bc73a1080ea87ad4fe6d2b0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1841/agentshield_0.2.1841_linux_arm64.tar.gz"
      sha256 "0b140138a815e075abcb60ae7da0cfb6c09f4ef1c7c42e815c7a61e577e3355c"
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
